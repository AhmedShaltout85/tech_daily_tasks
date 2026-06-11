package com.a08r.tasks_emp_complaint.service;

import com.a08r.tasks_emp_complaint.dto.PlaceItemRequest;
import com.a08r.tasks_emp_complaint.dto.PlaceItemResponse;

import java.util.List;

public interface PlaceItemService {

    PlaceItemResponse createItem(PlaceItemRequest request);

    List<PlaceItemResponse> getAllItems();

    PlaceItemResponse getItemById(Long id);

    PlaceItemResponse updateItem(Long id, PlaceItemRequest request);

    void deleteItem(Long id);

    List<PlaceItemResponse> getByPlaceName(String placeName);
}
