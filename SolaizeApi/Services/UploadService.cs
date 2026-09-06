using Microsoft.AspNetCore.Http;

namespace SolaizeApi.Services;

public class UploadService
{
    private readonly IWebHostEnvironment _env;
    private readonly ILogger<UploadService> _logger;

    public UploadService(IWebHostEnvironment env, ILogger<UploadService> logger)
    {
        _env = env;
        _logger = logger;
    }

    public async Task<string> SaveFileAsync(IFormFile file, string subFolder = "uploads")
    {
        if (file == null || file.Length == 0) throw new ArgumentException("File is empty");

        var uploadsRoot = Path.Combine(_env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot"), subFolder);
        Directory.CreateDirectory(uploadsRoot);

        var ext = Path.GetExtension(file.FileName);
        var fileName = $"{Guid.NewGuid():N}{ext}";
        var filePath = Path.Combine(uploadsRoot, fileName);

        using var stream = File.Create(filePath);
        await file.CopyToAsync(stream);

        _logger.LogInformation("Saved file {File} to {Path}", file.FileName, filePath);

        // Return relative path usable by clients
        return $"/{subFolder}/{fileName}";
    }
}