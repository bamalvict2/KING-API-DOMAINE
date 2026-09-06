using MongoDB.Driver;
using Microsoft.Extensions.Options;
using SolaizeApi;
using SolaizeApi.Services;
using SolaizeApi.Models;
using Prometheus;

var builder = WebApplication.CreateBuilder(args);

// Monitoring (Prometheus)
builder.Services.AddHealthChecks(); // OK
// ❌ Supprimer AddMetrics() — ce n’est pas Prometheus-net

// Load Mongo settings
builder.Services.Configure<MongoSettings>(
    builder.Configuration.GetSection("Mongo"));

// MongoClient
builder.Services.AddSingleton<IMongoClient>(sp =>
{
    var settings = sp.GetRequiredService<IOptions<MongoSettings>>().Value;
    return new MongoClient(settings.ConnectionString);
});

// MongoDatabase
builder.Services.AddSingleton<IMongoDatabase>(sp =>
{
    var settings = sp.GetRequiredService<IOptions<MongoSettings>>().Value;
    var client = sp.GetRequiredService<IMongoClient>();
    return client.GetDatabase(settings.Database);
});

// MongoCollection<Item>
builder.Services.AddSingleton<IMongoCollection<Item>>(sp =>
{
    var settings = sp.GetRequiredService<IOptions<MongoSettings>>().Value;
    var database = sp.GetRequiredService<IMongoDatabase>();
    return database.GetCollection<Item>(settings.Collection);
});

// Services
builder.Services.AddScoped<ItemService>();
builder.Services.AddScoped<UploadService>();

builder.Services.AddControllers();

var app = builder.Build();

// Prometheus
app.UseMetricServer();   // Expose /metrics
app.MapMetrics();        // Middleware Prometheus

app.MapControllers();

app.Run();