using Microsoft.AspNetCore.Mvc;
using SolaizeApi.Services;

namespace SolaizeApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UploadController : ControllerBase
{
    private readonly UploadService _uploadService;
    private readonly ILogger<UploadController> _logger;

    public UploadController(UploadService uploadService, ILogger<UploadController> logger)
    {
        _uploadService = uploadService;
        _logger = logger;
    }

    [HttpPost]
    [Route("file")]
    public async Task<IActionResult> UploadFile([FromForm] IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest("No file provided");
        }

        try
        {
            var url = await _uploadService.SaveFileAsync(file, "images");
            return Ok(new { url });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error while saving uploaded file");
            return StatusCode(500, "Internal server error");
        }
    }
}