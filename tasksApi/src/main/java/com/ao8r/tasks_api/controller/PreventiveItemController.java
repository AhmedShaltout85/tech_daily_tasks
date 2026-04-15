package com.ao8r.tasks_api.controller;

import com.ao8r.tasks_api.dto.PreventiveItemRequest;
import com.ao8r.tasks_api.dto.PreventiveItemResponse;
import com.ao8r.tasks_api.dto.MessageResponse;
import com.ao8r.tasks_api.service.PreventiveItemService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/preventive-items")
@RequiredArgsConstructor
@Slf4j
public class PreventiveItemController {

    private final PreventiveItemService preventiveItemService;

    @PostMapping
    public ResponseEntity<PreventiveItemResponse> createItem(@Valid @RequestBody PreventiveItemRequest request) {
        log.info("Creating new preventive item: {}", request.getAppName());
        PreventiveItemResponse response = preventiveItemService.createItem(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<PreventiveItemResponse>> getAllItems() {
        log.debug("Fetching all preventive items");
        List<PreventiveItemResponse> items = preventiveItemService.getAllItems();
        return ResponseEntity.ok(items);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PreventiveItemResponse> getItemById(@PathVariable Long id) {
        log.debug("Fetching preventive item by id: {}", id);
        PreventiveItemResponse response = preventiveItemService.getItemById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/app/{appName}")
    public ResponseEntity<PreventiveItemResponse> getItemByAppName(@PathVariable String appName) {
        log.debug("Fetching preventive item by app name: {}", appName);
        PreventiveItemResponse response = preventiveItemService.getItemByAppName(appName);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/app/{appName}/actions")
    public ResponseEntity<List<String>> getActionsByAppName(@PathVariable String appName) {
        log.debug("Fetching actions by app name: {}", appName);
        List<String> actions = preventiveItemService.getActionsByAppName(appName);
        return ResponseEntity.ok(actions);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PreventiveItemResponse> updateItem(@PathVariable Long id, 
                                                   @Valid @RequestBody PreventiveItemRequest request) {
        log.info("Updating preventive item with id: {}", id);
        PreventiveItemResponse response = preventiveItemService.updateItem(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteItem(@PathVariable Long id) {
        log.info("Deleting preventive item with id: {}", id);
        preventiveItemService.deleteItem(id);
        return ResponseEntity.ok(new MessageResponse("Preventive item deleted successfully!"));
    }
}