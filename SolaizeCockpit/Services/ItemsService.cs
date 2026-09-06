using System.Net.Http;
using System.Net.Http.Json;
using Solaize.Shared.Models;

namespace SolaizeCockpit.Services;

public class ItemsService
{
    private readonly HttpClient _http;

    public ItemsService(HttpClient http)
    {
        _http = http;
    }

    private const string BaseUrl = "http://solaize-api:8080/api/items";

    public async Task<List<ItemDto>> GetItemsAsync()
    {
        try
        {
            return await _http.GetFromJsonAsync<List<ItemDto>>(BaseUrl)
                   ?? new List<ItemDto>();
        }
        catch
        {
            return new List<ItemDto>();
        }
    }

    public async Task<ItemDto?> GetItemAsync(string id)
    {
        try
        {
            return await _http.GetFromJsonAsync<ItemDto>($"{BaseUrl}/{id}");
        }
        catch
        {
            return null;
        }
    }

    public async Task<bool> CreateItemAsync(ItemCreateDto item)
    {
        try
        {
            var res = await _http.PostAsJsonAsync(BaseUrl, item);
            return res.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }

    public async Task<bool> DeleteItemAsync(string id)
    {
        try
        {
            var res = await _http.DeleteAsync($"{BaseUrl}/{id}");
            return res.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }
}