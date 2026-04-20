package com.ao8r.tasks_api.controller;

import com.ao8r.tasks_api.dto.PlaceItemRequest;
import com.ao8r.tasks_api.dto.PlaceItemResponse;
import com.ao8r.tasks_api.dto.MessageResponse;
import com.ao8r.tasks_api.service.PlaceItemService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/place-items")
@CrossOrigin(origins ="*" )  // Allow CORS for Flutter Web
@RequiredArgsConstructor
@Slf4j
public class PlaceItemController {

    private final PlaceItemService placeItemService;

    @PostMapping
    public ResponseEntity<PlaceItemResponse> createItem(@Valid @RequestBody PlaceItemRequest request) {
        log.info("Creating new place item: {}", request.getPlaceName());
        PlaceItemResponse response = placeItemService.createItem(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<PlaceItemResponse>> getAllItems() {
        log.debug("Fetching all place items");
        List<PlaceItemResponse> items = placeItemService.getAllItems();
        return ResponseEntity.ok(items);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PlaceItemResponse> getItemById(@PathVariable Long id) {
        log.debug("Fetching place item by id: {}", id);
        PlaceItemResponse response = placeItemService.getItemById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/names")
    public ResponseEntity<List<String>> getAllPlaceNames() {
        log.debug("Fetching all place names");
        List<String> placeNames = placeItemService.getAllPlaceNames();
        return ResponseEntity.ok(placeNames);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PlaceItemResponse> updateItem(@PathVariable Long id, 
                                                   @Valid @RequestBody PlaceItemRequest request) {
        log.info("Updating place item with id: {}", id);
        PlaceItemResponse response = placeItemService.updateItem(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteItem(@PathVariable Long id) {
        log.info("Deleting place item with id: {}", id);
        placeItemService.deleteItem(id);
        return ResponseEntity.ok(new MessageResponse("Place item deleted successfully!"));
    }
}