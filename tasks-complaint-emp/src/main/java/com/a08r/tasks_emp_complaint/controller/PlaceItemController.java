package com.a08r.tasks_emp_complaint.controller;

import com.a08r.tasks_emp_complaint.dto.PlaceItemRequest;
import com.a08r.tasks_emp_complaint.dto.PlaceItemResponse;
import com.a08r.tasks_emp_complaint.dto.MessageResponse;
import com.a08r.tasks_emp_complaint.service.PlaceItemService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/place-items")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
@Slf4j
public class PlaceItemController {

    private final PlaceItemService placeItemService;

    @PostMapping
    public ResponseEntity<PlaceItemResponse> createItem(@Valid @RequestBody PlaceItemRequest request) {
        log.info("Received request to create place item: {}", request.getPlaceName());
        PlaceItemResponse response = placeItemService.createItem(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<PlaceItemResponse>> getAllItems() {
        log.info("Received request to get all place items");
        List<PlaceItemResponse> items = placeItemService.getAllItems();
        return ResponseEntity.ok(items);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PlaceItemResponse> getItemById(@PathVariable Long id) {
        log.info("Received request to get place item by id: {}", id);
        PlaceItemResponse response = placeItemService.getItemById(id);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PlaceItemResponse> updateItem(@PathVariable Long id,
                                                        @Valid @RequestBody PlaceItemRequest request) {
        log.info("Received request to update place item with id: {}", id);
        PlaceItemResponse response = placeItemService.updateItem(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteItem(@PathVariable Long id) {
        log.info("Received request to delete place item with id: {}", id);
        placeItemService.deleteItem(id);
        return ResponseEntity.ok(new MessageResponse("Place item deleted successfully!"));
    }

    @GetMapping("/place/{placeName}")
    public ResponseEntity<List<PlaceItemResponse>> getByPlaceName(@PathVariable String placeName) {
        log.info("Received request to get place items by place name: {}", placeName);
        List<PlaceItemResponse> items = placeItemService.getByPlaceName(placeName);
        return ResponseEntity.ok(items);
    }
}
