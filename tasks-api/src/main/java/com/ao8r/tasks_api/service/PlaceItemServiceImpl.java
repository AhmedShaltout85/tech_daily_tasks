package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.PlaceItemRequest;
import com.ao8r.tasks_api.dto.PlaceItemResponse;
import com.ao8r.tasks_api.entity.PlaceItem;
import com.ao8r.tasks_api.exception.ResourceNotFoundException;
import com.ao8r.tasks_api.repository.PlaceItemRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class PlaceItemServiceImpl implements PlaceItemService {

    private final PlaceItemRepository placeItemRepository;

    @Override
    @Transactional
    public PlaceItemResponse createItem(PlaceItemRequest request) {
        log.debug("Creating new place item: {}", request.getPlaceName());

        PlaceItem item = PlaceItem.builder()
                .placeName(request.getPlaceName())
                .build();

        PlaceItem savedItem = placeItemRepository.save(item);
        log.info("Place item created successfully with id: {}", savedItem.getId());

        return mapToResponse(savedItem);
    }

    @Override
    public List<PlaceItemResponse> getAllItems() {
        log.debug("Fetching all place items");
        return placeItemRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public PlaceItemResponse getItemById(Long id) {
        log.debug("Fetching place item by id: {}", id);
        PlaceItem item = placeItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Place item not found with id: " + id));
        return mapToResponse(item);
    }

    @Override
    public List<String> getAllPlaceNames() {
        log.debug("Fetching all place names");
        return placeItemRepository.findAllPlaceNames();
    }

    @Override
    @Transactional
    public PlaceItemResponse updateItem(Long id, PlaceItemRequest request) {
        log.debug("Updating place item with id: {}", id);

        PlaceItem item = placeItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Place item not found with id: " + id));

        item.setPlaceName(request.getPlaceName());

        PlaceItem updatedItem = placeItemRepository.save(item);
        log.info("Place item updated successfully with id: {}", updatedItem.getId());

        return mapToResponse(updatedItem);
    }

    @Override
    @Transactional
    public void deleteItem(Long id) {
        log.debug("Deleting place item with id: {}", id);

        if (!placeItemRepository.existsById(id)) {
            throw new ResourceNotFoundException("Place item not found with id: " + id);
        }

        placeItemRepository.deleteById(id);
        log.info("Place item deleted successfully with id: {}", id);
    }

    private PlaceItemResponse mapToResponse(PlaceItem item) {
        return PlaceItemResponse.builder()
                .id(item.getId())
                .placeName(item.getPlaceName())
                .build();
    }
}