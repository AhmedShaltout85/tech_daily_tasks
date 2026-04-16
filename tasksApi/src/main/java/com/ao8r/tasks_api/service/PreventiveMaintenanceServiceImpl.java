package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.PreventiveMaintenanceRequest;
import com.ao8r.tasks_api.dto.PreventiveMaintenanceResponse;
import com.ao8r.tasks_api.entity.PreventiveMaintenance;
import com.ao8r.tasks_api.exception.ResourceNotFoundException;
import com.ao8r.tasks_api.repository.PreventiveMaintenanceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class PreventiveMaintenanceServiceImpl implements PreventiveMaintenanceService {

    private final PreventiveMaintenanceRepository preventiveMaintenanceRepository;

    @Override
    @Transactional
    public PreventiveMaintenanceResponse createItem(PreventiveMaintenanceRequest request) {
        log.debug("Creating new preventive maintenance: {}", request.getAppName());

        PreventiveMaintenance item = PreventiveMaintenance.builder()
                .appName(request.getAppName())
                .action(request.getAction())
                .username(request.getUsername())
                .placeName(request.getPlaceName())
                .subPlace(request.getSubPlace() != null ? request.getSubPlace() : "none")
                .isRemote(request.getIsRemote() != null ? request.getIsRemote() : false)
                .build();

        PreventiveMaintenance savedItem = preventiveMaintenanceRepository.save(item);
        log.info("Preventive maintenance created successfully with id: {}", savedItem.getId());

        return mapToResponse(savedItem);
    }

    @Override
    public List<PreventiveMaintenanceResponse> getAllItems() {
        log.debug("Fetching all preventive maintenance items");
        return preventiveMaintenanceRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public PreventiveMaintenanceResponse getItemById(Long id) {
        log.debug("Fetching preventive maintenance by id: {}", id);
        PreventiveMaintenance item = preventiveMaintenanceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Preventive maintenance not found with id: " + id));
        return mapToResponse(item);
    }

    @Override
    @Transactional
    public PreventiveMaintenanceResponse updateItem(Long id, PreventiveMaintenanceRequest request) {
        log.debug("Updating preventive maintenance with id: {}", id);

        PreventiveMaintenance item = preventiveMaintenanceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Preventive maintenance not found with id: " + id));

        item.setAppName(request.getAppName());
        item.setAction(request.getAction());
        item.setUsername(request.getUsername());
        item.setPlaceName(request.getPlaceName());
        item.setSubPlace(request.getSubPlace() != null ? request.getSubPlace() : "none");
        item.setIsRemote(request.getIsRemote() != null ? request.getIsRemote() : false);

        PreventiveMaintenance updatedItem = preventiveMaintenanceRepository.save(item);
        log.info("Preventive maintenance updated successfully with id: {}", updatedItem.getId());

        return mapToResponse(updatedItem);
    }

    @Override
    @Transactional
    public void deleteItem(Long id) {
        log.debug("Deleting preventive maintenance with id: {}", id);

        if (!preventiveMaintenanceRepository.existsById(id)) {
            throw new ResourceNotFoundException("Preventive maintenance not found with id: " + id);
        }

        preventiveMaintenanceRepository.deleteById(id);
        log.info("Preventive maintenance deleted successfully with id: {}", id);
    }

    // Filter implementations
    @Override
    public List<PreventiveMaintenanceResponse> getByAppName(String appName) {
        return preventiveMaintenanceRepository.findByAppName(appName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PreventiveMaintenanceResponse> getByUsername(String username) {
        return preventiveMaintenanceRepository.findByUsername(username).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PreventiveMaintenanceResponse> getByPlaceName(String placeName) {
        return preventiveMaintenanceRepository.findByPlaceName(placeName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PreventiveMaintenanceResponse> getBySubPlace(String subPlace) {
        return preventiveMaintenanceRepository.findBySubPlace(subPlace).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PreventiveMaintenanceResponse> getByIsRemote(Boolean isRemote) {
        return preventiveMaintenanceRepository.findByIsRemote(isRemote).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PreventiveMaintenanceResponse> getByAppNameAndUsername(String appName, String username) {
        return preventiveMaintenanceRepository.findByAppNameAndUsername(appName, username).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PreventiveMaintenanceResponse> getByAppNameAndPlaceName(String appName, String placeName) {
        return preventiveMaintenanceRepository.findByAppNameAndPlaceName(appName, placeName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PreventiveMaintenanceResponse> getByUsernameAndPlaceName(String username, String placeName) {
        return preventiveMaintenanceRepository.findByUsernameAndPlaceName(username, placeName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PreventiveMaintenanceResponse> getByAppNameAndIsRemote(String appName, Boolean isRemote) {
        return preventiveMaintenanceRepository.findByAppNameAndIsRemote(appName, isRemote).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PreventiveMaintenanceResponse> getByUsernameAndIsRemote(String username, Boolean isRemote) {
        return preventiveMaintenanceRepository.findByUsernameAndIsRemote(username, isRemote).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PreventiveMaintenanceResponse> getByPlaceNameAndIsRemote(String placeName, Boolean isRemote) {
        return preventiveMaintenanceRepository.findByPlaceNameAndIsRemote(placeName, isRemote).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private PreventiveMaintenanceResponse mapToResponse(PreventiveMaintenance item) {
        return PreventiveMaintenanceResponse.builder()
                .id(item.getId())
                .appName(item.getAppName())
                .action(item.getAction())
                .username(item.getUsername())
                .placeName(item.getPlaceName())
                .subPlace(item.getSubPlace())
                .isRemote(item.getIsRemote())
                .createdAt(item.getCreatedAt())
                .build();
    }
}