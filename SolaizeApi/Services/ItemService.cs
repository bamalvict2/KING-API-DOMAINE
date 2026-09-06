using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MongoDB.Driver;
using Solaize.Shared.Models;
using Solaize.Shared.Services;
using SolaizeApi.Models;

namespace SolaizeApi.Services;

public class ItemService 
{
    private readonly IMongoCollection<Item> _collection;

    public ItemService(IMongoClient mongoClient)
    {
        var db = mongoClient.GetDatabase("SolaizeDb");
        _collection = db.GetCollection<Item>("Items");
    }

    public async Task<IEnumerable<ItemListDto>> GetAllAsync()
    {
        var items = await _collection.Find(_ => true).ToListAsync();
        return items.Select(i => new ItemListDto
        {
            Id = i.Id,
            Title = i.Title,
            PhotoFileName = i.PhotoFileName   // ✔️ CORRECT
        });
    }

    public async Task<ItemDto?> GetByIdAsync(string id)
    {
        var item = await _collection.Find(i => i.Id == id).FirstOrDefaultAsync();
        if (item == null) return null;

        return new ItemDto
        {
            Id = item.Id,
            Title = item.Title,
            Description = item.Description,
            PhotoFileName = item.PhotoFileName   // ✔️ CORRECT
        };
    }

    public async Task<ItemDto> CreateAsync(ItemCreateDto dto)
    {
        var item = new Item
        {
            Title = dto.Title,
            Description = dto.Description,
            PhotoFileName = dto.PhotoFileName   // ✔️ CORRECT
        };

        await _collection.InsertOneAsync(item);

        return new ItemDto
        {
            Id = item.Id,
            Title = item.Title,
            Description = item.Description,
            PhotoFileName = item.PhotoFileName   // ✔️ CORRECT
        };
    }

    public async Task UpdateAsync(string id, ItemUpdateDto dto)
    {
        var update = Builders<Item>.Update
            .Set(i => i.Title, dto.Title)
            .Set(i => i.Description, dto.Description)
            .Set(i => i.PhotoFileName, dto.PhotoFileName);   // ✔️ CORRECT

        await _collection.UpdateOneAsync(i => i.Id == id, update);
    }

    public async Task DeleteAsync(string id)
    {
        await _collection.DeleteOneAsync(i => i.Id == id);
    }
}