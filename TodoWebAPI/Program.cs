using Microsoft.EntityFrameworkCore;
        using MyWebApi.Data;

        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.

        builder.Services.AddControllers();
        // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen();

        builder.Services.AddDbContext<TodoContext>(options =>
            options.UseMySql(builder.Configuration.GetConnectionString("DefaultConnection"),
            new MySqlServerVersion(new Version(8, 0, 29)))); // Replace with your MySQL version
        var app = builder.Build();

        // Log configured endpoints
        var logger = app.Services.GetRequiredService<ILogger<Program>>();
        var endpoints = app.Configuration.GetSection("Kestrel:Endpoints").GetChildren();
        foreach (var endpoint in endpoints)
        {
            logger.LogInformation("Configured endpoint: {Name} at {Url}",
                endpoint.Key, endpoint["Url"]);
        }

        // Configure the HTTP request pipeline.
        app.UseSwagger();
        app.UseSwaggerUI(options =>
        {
            options.SwaggerEndpoint("/swagger/v1/swagger.json", "v1");
            options.RoutePrefix = "api-docs";
        });

        //app.UseHttpsRedirection();

        app.UseAuthorization();

        app.MapControllers();

        app.Run();