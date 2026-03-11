import pytest
from things_server import add_todo, get_todos, get_today, search_todos


@pytest.mark.asyncio
async def test_get_todos_includes_checklist(mocker, mock_todo):
    mock_things_todos = mocker.patch('things.todos')
    mock_things_todos.return_value = [mock_todo]

    result = await get_todos.fn(include_items=True)

    assert "Checklist:" in result
    assert "First item" in result
    mock_things_todos.assert_called_once_with(project=None, start=None, include_items=True)


@pytest.mark.asyncio
async def test_get_today_includes_checklist(mocker, mock_todo):
    mock_today = mocker.patch('things.today')
    mock_today.return_value = [mock_todo]

    result = await get_today.fn()

    assert "Checklist:" in result
    assert "First item" in result
    mock_today.assert_called_once_with(include_items=True)


@pytest.mark.asyncio
async def test_search_todos_includes_checklist(mocker, mock_todo):
    mock_search = mocker.patch('things.search')
    mock_search.return_value = [mock_todo]

    result = await search_todos.fn("Test")

    assert "Checklist:" in result
    assert "First item" in result
    mock_search.assert_called_once_with("Test", include_items=True)


@pytest.mark.asyncio
async def test_add_todo_verifies_created_item(mocker, mock_todo):
    mocker.patch("url_scheme.execute_url")
    mock_search = mocker.patch("things.search")
    mock_search.return_value = [mock_todo]
    mock_last = mocker.patch("things.last")
    mock_last.return_value = []

    result = await add_todo.fn("Test Todo", notes="Test notes", tags=["work", "urgent"])

    assert result["ok"] is True
    assert result["verified"] is True
    assert result["id"] == "test-todo-uuid"
    assert result["verification_source"] == "search_todos:title"
    mock_search.assert_called_once_with("Test Todo", include_items=True)
    mock_last.assert_not_called()


@pytest.mark.asyncio
async def test_add_todo_uses_recent_fallback(mocker, mock_todo):
    mocker.patch("url_scheme.execute_url")
    mock_search = mocker.patch("things.search")
    mock_search.return_value = []
    mock_last = mocker.patch("things.last")
    mock_last.return_value = [mock_todo]

    result = await add_todo.fn("Test Todo", notes="Test notes", tags=["work", "urgent"])

    assert result["ok"] is True
    assert result["verification_source"] == "get_recent:1d"
    mock_search.assert_called_once_with("Test Todo", include_items=True)
    mock_last.assert_called_once_with("1d", include_items=True)


@pytest.mark.asyncio
async def test_add_todo_raises_when_verification_fails(mocker):
    mocker.patch("url_scheme.execute_url")
    mocker.patch("things.search", return_value=[])
    mocker.patch("things.last", return_value=[])
    mocker.patch("things_server.VERIFY_WRITE_DELAY_SECONDS", 0)

    with pytest.raises(RuntimeError, match="could not be confirmed"):
        await add_todo.fn("Missing Todo")


@pytest.mark.asyncio
async def test_add_todo_raises_on_ambiguous_matches(mocker, mock_todo):
    mocker.patch("url_scheme.execute_url")
    duplicate = dict(mock_todo)
    duplicate["uuid"] = "duplicate-uuid"
    mocker.patch("things.search", return_value=[mock_todo, duplicate])
    mocker.patch("things.last", return_value=[mock_todo, duplicate])
    mocker.patch("things_server.VERIFY_WRITE_DELAY_SECONDS", 0)

    with pytest.raises(RuntimeError, match="could not be confirmed"):
        await add_todo.fn("Test Todo", notes="Test notes", tags=["work", "urgent"])
