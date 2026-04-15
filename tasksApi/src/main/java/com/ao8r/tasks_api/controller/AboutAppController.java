package com.ao8r.tasks_api.controller;

import com.ao8r.tasks_api.dto.AboutAppRequest;
import com.ao8r.tasks_api.dto.AboutAppResponse;
import com.ao8r.tasks_api.dto.MessageResponse;
import com.ao8r.tasks_api.service.AboutAppService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/about-apps")
@RequiredArgsConstructor
@Slf4j
public class AboutAppController {

    private final AboutAppService aboutAppService;

    @PostMapping
    public ResponseEntity<AboutAppResponse> createApp(@Valid @RequestBody AboutAppRequest request) {
        log.info("Creating new about app: {}", request.getAppName());
        AboutAppResponse response = aboutAppService.createApp(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<AboutAppResponse>> getAllApps() {
        log.debug("Fetching all about apps");
        List<AboutAppResponse> apps = aboutAppService.getAllApps();
        return ResponseEntity.ok(apps);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AboutAppResponse> getAppById(@PathVariable Long id) {
        log.debug("Fetching about app by id: {}", id);
        AboutAppResponse response = aboutAppService.getAppById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/name/{appName}")
    public ResponseEntity<AboutAppResponse> getAppByAppName(@PathVariable String appName) {
        log.debug("Fetching about app by app name: {}", appName);
        AboutAppResponse response = aboutAppService.getAppByAppName(appName);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/name/{appName}/recommended")
    public ResponseEntity<List<String>> getRecommendedByAppName(@PathVariable String appName) {
        log.debug("Fetching recommended values by app name: {}", appName);
        List<String> recommended = aboutAppService.getRecommendedByAppName(appName);
        return ResponseEntity.ok(recommended);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AboutAppResponse> updateApp(@PathVariable Long id, 
                                                   @Valid @RequestBody AboutAppRequest request) {
        log.info("Updating about app with id: {}", id);
        AboutAppResponse response = aboutAppService.updateApp(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteApp(@PathVariable Long id) {
        log.info("Deleting about app with id: {}", id);
        aboutAppService.deleteApp(id);
        return ResponseEntity.ok(new MessageResponse("About app deleted successfully!"));
    }
}