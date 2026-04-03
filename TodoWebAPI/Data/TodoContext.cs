using Microsoft.EntityFrameworkCore;
        using MyWebApi.Models;

        namespace MyWebApi.Data;

        public class TodoContext : DbContext
        {
            public TodoContext(DbContextOptions<TodoContext> options) : base(options)
            {
            }

            public DbSet<TodoItem> TodoItems { get; set; } = null!;
        }