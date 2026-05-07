using Microsoft.EntityFrameworkCore;
using TodoApi.Data;
using TodoApi.DTOs;
using TodoApi.Models;

namespace TodoApi.Services
{
    /// <summary>
    /// CRUD operations for TodoItems scoped to the authenticated user.
    /// </summary>
    public class TodoService
    {
        private readonly AppDbContext _db;

        public TodoService(AppDbContext db)
        {
            _db = db;
        }

        // ── Get all todos for a user ──────────────────────────
        public async Task<List<TodoResponseDto>> GetTodosAsync(string userId)
        {
            return await _db.Todos
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.CreatedAt)
                .Select(t => MapToDto(t))
                .ToListAsync();
        }

        // ── Get single todo ───────────────────────────────────
        public async Task<TodoResponseDto?> GetTodoByIdAsync(int id, string userId)
        {
            var todo = await _db.Todos
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
            return todo == null ? null : MapToDto(todo);
        }

        // ── Create todo ───────────────────────────────────────
        public async Task<TodoResponseDto> CreateTodoAsync(string userId, CreateTodoDto dto)
        {
            var todo = new TodoItem
            {
                Title = dto.Title,
                Description = dto.Description,
                UserId = userId,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _db.Todos.Add(todo);
            await _db.SaveChangesAsync();
            return MapToDto(todo);
        }

        // ── Update todo ───────────────────────────────────────
        public async Task<bool> UpdateTodoAsync(int id, string userId, UpdateTodoDto dto)
        {
            var todo = await _db.Todos
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
            if (todo == null) return false;

            todo.Title = dto.Title;
            todo.Description = dto.Description;
            todo.IsCompleted = dto.IsCompleted;
            todo.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync();
            return true;
        }

        // ── Delete todo ───────────────────────────────────────
        public async Task<bool> DeleteTodoAsync(int id, string userId)
        {
            var todo = await _db.Todos
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
            if (todo == null) return false;

            _db.Todos.Remove(todo);
            await _db.SaveChangesAsync();
            return true;
        }

        // ── Mapping helper ────────────────────────────────────
        private static TodoResponseDto MapToDto(TodoItem t) => new()
        {
            Id = t.Id,
            Title = t.Title,
            Description = t.Description,
            IsCompleted = t.IsCompleted,
            CreatedAt = t.CreatedAt,
            UpdatedAt = t.UpdatedAt,
        };
    }
}
