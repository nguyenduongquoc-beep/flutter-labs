using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoApi.DTOs;
using TodoApi.Services;

namespace TodoApi.Controllers
{
    /// <summary>
    /// CRUD endpoints for Todos. All routes require JWT authentication.
    /// GET    /api/todos         → Get all todos for current user
    /// POST   /api/todos         → Create a new todo
    /// PUT    /api/todos/{id}    → Update a todo
    /// DELETE /api/todos/{id}    → Delete a todo
    /// </summary>
    [ApiController]
    [Route("api/todos")]
    [Authorize]
    public class TodoController : ControllerBase
    {
        private readonly TodoService _todoService;

        public TodoController(TodoService todoService)
        {
            _todoService = todoService;
        }

        // Helper: get current user ID from JWT claims
        private string GetUserId() =>
            User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub")
            ?? string.Empty;

        // GET /api/todos
        [HttpGet]
        public async Task<IActionResult> GetTodos()
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized();

            var todos = await _todoService.GetTodosAsync(userId);
            return Ok(todos);
        }

        // GET /api/todos/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetTodo(int id)
        {
            var userId = GetUserId();
            var todo = await _todoService.GetTodoByIdAsync(id, userId);
            if (todo == null) return NotFound(new { message = "Không tìm thấy công việc." });
            return Ok(todo);
        }

        // POST /api/todos
        [HttpPost]
        public async Task<IActionResult> CreateTodo([FromBody] CreateTodoDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Title))
                return BadRequest(new { message = "Tiêu đề không được để trống." });

            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var todo = await _todoService.CreateTodoAsync(userId, dto);
            return CreatedAtAction(nameof(GetTodo), new { id = todo.Id }, todo);
        }

        // PUT /api/todos/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTodo(int id, [FromBody] UpdateTodoDto dto)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var updated = await _todoService.UpdateTodoAsync(id, userId, dto);
            if (!updated) return NotFound(new { message = "Không tìm thấy công việc." });
            return NoContent();
        }

        // DELETE /api/todos/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTodo(int id)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var deleted = await _todoService.DeleteTodoAsync(id, userId);
            if (!deleted) return NotFound(new { message = "Không tìm thấy công việc." });
            return NoContent();
        }
    }
}
