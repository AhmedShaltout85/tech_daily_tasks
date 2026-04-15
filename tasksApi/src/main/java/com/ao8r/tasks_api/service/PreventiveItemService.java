package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.PreventiveItemRequest;
import com.ao8r.tasks_api.dto.PreventiveItemResponse;

import java.util.List;

public interface PreventiveItemService {

    PreventiveItemResponse createItem(PreventiveItemRequest request);

    List<PreventiveItemResponse> getAllItems();

    PreventiveItemResponse getItemById(Long id);

    PreventiveItemResponse getItemByAppName(String appName);

    List<String> getActionsByAppName(String appName);

    PreventiveItemResponse updateItem(Long id, PreventiveItemRequest request);

    void deleteItem(Long id);
}