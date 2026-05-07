namespace TodoApi.Models
{
    /// <summary>
    /// Todo item entity stored in the database.
    /// Each todo belongs to one ApplicationUser.
    /// </summary>
    public class TodoItem
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public bool IsCompleted { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Foreign key → ApplicationUser
        public string UserId { get; set; } = string.Empty;
        public ApplicationUser? User { get; set; }
    }
}
