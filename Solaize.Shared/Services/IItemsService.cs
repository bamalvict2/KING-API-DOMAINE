using System.Collections.Generic;
using System.Threading.Tasks;
using Solaize.Shared.Models;

namespace Solaize.Shared.Services;

public interface IItemsService
{
    Task<IEnumerable<ItemListDto>> GetAllAsync();
    Task<ItemDto?> GetByIdAsync(string id);
    Task<ItemDto> CreateAsync(ItemCreateDto dto);
    Task UpdateAsync(string id, ItemUpdateDto dto);
    Task DeleteAsync(string id);
}