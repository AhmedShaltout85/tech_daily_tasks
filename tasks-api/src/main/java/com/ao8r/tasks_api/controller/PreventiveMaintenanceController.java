package com.ao8r.tasks_api.controller;

import com.ao8r.tasks_api.dto.PreventiveMaintenanceRequest;
import com.ao8r.tasks_api.dto.PreventiveMaintenanceResponse;
import com.ao8r.tasks_api.dto.MessageResponse;
import com.ao8r.tasks_api.service.PreventiveMaintenanceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/preventive-maintenance")
@CrossOrigin(origins ="*" )  // Allow CORS for Flutter Web
@RequiredArgsConstructor
@Slf4j
public class PreventiveMaintenanceController {

    private final PreventiveMaintenanceService preventiveMaintenanceService;

    @PostMapping
    public ResponseEntity<PreventiveMaintenanceResponse> createItem(@Valid @RequestBody PreventiveMaintenanceRequest request) {
        log.info("Creating new preventive maintenance: {}", request.getAppName());
        PreventiveMaintenanceResponse response = preventiveMaintenanceService.createItem(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getAllItems() {
        log.debug("Fetching all preventive maintenance items");
        List<PreventiveMaintenanceResponse> items = preventiveMaintenanceService.getAllItems();
        return ResponseEntity.ok(items);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PreventiveMaintenanceResponse> getItemById(@PathVariable Long id) {
        log.debug("Fetching preventive maintenance by id: {}", id);
        PreventiveMaintenanceResponse response = preventiveMaintenanceService.getItemById(id);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PreventiveMaintenanceResponse> updateItem(@PathVariable Long id, 
                                                   @Valid @RequestBody PreventiveMaintenanceRequest request) {
        log.info("Updating preventive maintenance with id: {}", id);
        PreventiveMaintenanceResponse response = preventiveMaintenanceService.updateItem(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteItem(@PathVariable Long id) {
        log.info("Deleting preventive maintenance with id: {}", id);
        preventiveMaintenanceService.deleteItem(id);
        return ResponseEntity.ok(new MessageResponse("Preventive maintenance deleted successfully!"));
    }

    // Filter endpoints
    @GetMapping("/app/{appName}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getByAppName(@PathVariable String appName) {
        log.debug("Fetching by app name: {}", appName);
        return ResponseEntity.ok(preventiveMaintenanceService.getByAppName(appName));
    }

    @GetMapping("/user/{username}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getByUsername(@PathVariable String username) {
        log.debug("Fetching by username: {}", username);
        return ResponseEntity.ok(preventiveMaintenanceService.getByUsername(username));
    }

    @GetMapping("/place/{placeName}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getByPlaceName(@PathVariable String placeName) {
        log.debug("Fetching by place name: {}", placeName);
        return ResponseEntity.ok(preventiveMaintenanceService.getByPlaceName(placeName));
    }

    @GetMapping("/sub-place/{subPlace}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getBySubPlace(@PathVariable String subPlace) {
        log.debug("Fetching by sub place: {}", subPlace);
        return ResponseEntity.ok(preventiveMaintenanceService.getBySubPlace(subPlace));
    }

    @GetMapping("/remote/{isRemote}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getByIsRemote(@PathVariable Boolean isRemote) {
        log.debug("Fetching by isRemote: {}", isRemote);
        return ResponseEntity.ok(preventiveMaintenanceService.getByIsRemote(isRemote));
    }

    @GetMapping("/app/{appName}/user/{username}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getByAppNameAndUsername(
            @PathVariable String appName, @PathVariable String username) {
        log.debug("Fetching by app name and username: {}, {}", appName, username);
        return ResponseEntity.ok(preventiveMaintenanceService.getByAppNameAndUsername(appName, username));
    }

    @GetMapping("/app/{appName}/place/{placeName}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getByAppNameAndPlaceName(
            @PathVariable String appName, @PathVariable String placeName) {
        log.debug("Fetching by app name and place name: {}, {}", appName, placeName);
        return ResponseEntity.ok(preventiveMaintenanceService.getByAppNameAndPlaceName(appName, placeName));
    }

    @GetMapping("/user/{username}/place/{placeName}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getByUsernameAndPlaceName(
            @PathVariable String username, @PathVariable String placeName) {
        log.debug("Fetching by username and place name: {}, {}", username, placeName);
        return ResponseEntity.ok(preventiveMaintenanceService.getByUsernameAndPlaceName(username, placeName));
    }

    @GetMapping("/app/{appName}/remote/{isRemote}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getByAppNameAndIsRemote(
            @PathVariable String appName, @PathVariable Boolean isRemote) {
        log.debug("Fetching by app name and isRemote: {}, {}", appName, isRemote);
        return ResponseEntity.ok(preventiveMaintenanceService.getByAppNameAndIsRemote(appName, isRemote));
    }

    @GetMapping("/user/{username}/remote/{isRemote}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getByUsernameAndIsRemote(
            @PathVariable String username, @PathVariable Boolean isRemote) {
        log.debug("Fetching by username and isRemote: {}, {}", username, isRemote);
        return ResponseEntity.ok(preventiveMaintenanceService.getByUsernameAndIsRemote(username, isRemote));
    }

    @GetMapping("/place/{placeName}/remote/{isRemote}")
    public ResponseEntity<List<PreventiveMaintenanceResponse>> getByPlaceNameAndIsRemote(
            @PathVariable String placeName, @PathVariable Boolean isRemote) {
        log.debug("Fetching by place name and isRemote: {}, {}", placeName, isRemote);
        return ResponseEntity.ok(preventiveMaintenanceService.getByPlaceNameAndIsRemote(placeName, isRemote));
    }
}