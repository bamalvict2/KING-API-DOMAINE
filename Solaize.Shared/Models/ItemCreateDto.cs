using System;

namespace Solaize.Shared.Models;

public class ItemCreateDto
{
    public string Title { get; set; } = default!;
    public string Description { get; set; } = default!;
    public string? PhotoFileName { get; set; }
}