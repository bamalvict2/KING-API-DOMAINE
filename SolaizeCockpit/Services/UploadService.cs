using System.Net.Http.Headers;

namespace SolaizeCockpit.Services;

public class UploadService
{
    private readonly HttpClient _http;

    public UploadService(HttpClient http)
    {
        _http = http;
    }

    public async Task<string?> UploadAsync(Stream fileStream, string fileName)
    {
        using var content = new MultipartFormDataContent();
        var fileContent = new StreamContent(fileStream);

        fileContent.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");

        content.Add(fileContent, "file", fileName);

        var response = await _http.PostAsync("api/upload", content);

        if (!response.IsSuccessStatusCode)
            return null;

        return await response.Content.ReadAsStringAsync();
    }
}