package com.ao8r.tasks_api.controller;

import com.ao8r.tasks_api.dto.AppsNameRequest;
import com.ao8r.tasks_api.dto.AppsNameResponse;
import com.ao8r.tasks_api.dto.MessageResponse;
import com.ao8r.tasks_api.service.AppsNameService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/apps")
@RequiredArgsConstructor
@Slf4j
public class AppsController {

    private final AppsNameService appsNameService;

    @PostMapping
    public ResponseEntity<AppsNameResponse> createApp(@Valid @RequestBody AppsNameRequest request) {
        log.debug("Create app request received");
        AppsNameResponse response = appsNameService.createApp(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<AppsNameResponse>> getAllApps() {
        log.debug("Get all apps request received");
        List<AppsNameResponse> apps = appsNameService.getAllApps();
        return ResponseEntity.ok(apps);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AppsNameResponse> getAppById(@PathVariable Long id) {
        log.debug("Get app by ID request received: {}", id);
        return appsNameService.getAppById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<AppsNameResponse> updateApp(@PathVariable Long id, @Valid @RequestBody AppsNameRequest request) {
        log.debug("Update app request received for ID: {}", id);
        AppsNameResponse response = appsNameService.updateApp(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteApp(@PathVariable Long id) {
        log.debug("Delete app request received for ID: {}", id);
        appsNameService.deleteApp(id);
        return ResponseEntity.ok(new MessageResponse("App deleted successfully!"));
    }
}