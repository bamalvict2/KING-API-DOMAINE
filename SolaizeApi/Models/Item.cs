using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace SolaizeApi.Models
{
 public class Item
    {
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = default!;
    
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? PhotoFileName { get; set; }
    }   
}