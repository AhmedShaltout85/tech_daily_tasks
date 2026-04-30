package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.PreventiveMaintenanceRequest;
import com.ao8r.tasks_api.dto.PreventiveMaintenanceResponse;

import java.util.List;

public interface PreventiveMaintenanceService {

    PreventiveMaintenanceResponse createItem(PreventiveMaintenanceRequest request);

    List<PreventiveMaintenanceResponse> getAllItems();

    PreventiveMaintenanceResponse getItemById(Long id);

    PreventiveMaintenanceResponse updateItem(Long id, PreventiveMaintenanceRequest request);

    void deleteItem(Long id);

    // Filters
    List<PreventiveMaintenanceResponse> getByAppName(String appName);

    List<PreventiveMaintenanceResponse> getByUsername(String username);

    List<PreventiveMaintenanceResponse> getByPlaceName(String placeName);

    List<PreventiveMaintenanceResponse> getBySubPlace(String subPlace);

    List<PreventiveMaintenanceResponse> getByIsRemote(Boolean isRemote);

    List<PreventiveMaintenanceResponse> getByAppNameAndUsername(String appName, String username);

    List<PreventiveMaintenanceResponse> getByAppNameAndPlaceName(String appName, String placeName);

    List<PreventiveMaintenanceResponse> getByUsernameAndPlaceName(String username, String placeName);

    List<PreventiveMaintenanceResponse> getByAppNameAndIsRemote(String appName, Boolean isRemote);

    List<PreventiveMaintenanceResponse> getByUsernameAndIsRemote(String username, Boolean isRemote);

    List<PreventiveMaintenanceResponse> getByPlaceNameAndIsRemote(String placeName, Boolean isRemote);
}