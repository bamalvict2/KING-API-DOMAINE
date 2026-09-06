using System;

namespace Solaize.Shared.Models;

public class ItemDto
{
    public string Id { get; set; } = default!;
    public string Title { get; set; } = default!;
    public string Description { get; set; } = default!;
    public string? PhotoFileName { get; set; }
}