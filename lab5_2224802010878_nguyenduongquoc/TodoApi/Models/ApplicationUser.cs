using Microsoft.AspNetCore.Identity;

namespace TodoApi.Models
{
    /// <summary>
    /// User entity extending IdentityUser (ASP.NET Core Identity).
    /// IdentityUser already provides: Id, Email, PasswordHash, etc.
    /// </summary>
    public class ApplicationUser : IdentityUser
    {
        public string FullName { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation property
        public ICollection<TodoItem> Todos { get; set; } = new List<TodoItem>();
    }
}
