package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.PlaceItemRequest;
import com.ao8r.tasks_api.dto.PlaceItemResponse;

import java.util.List;

public interface PlaceItemService {

    PlaceItemResponse createItem(PlaceItemRequest request);

    List<PlaceItemResponse> getAllItems();

    PlaceItemResponse getItemById(Long id);

    List<String> getAllPlaceNames();

    PlaceItemResponse updateItem(Long id, PlaceItemRequest request);

    void deleteItem(Long id);
}