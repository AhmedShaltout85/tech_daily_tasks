package com.a08r.tasks_emp_complaint.controller;

import com.a08r.tasks_emp_complaint.dto.AboutAppRequest;
import com.a08r.tasks_emp_complaint.dto.AboutAppResponse;
import com.a08r.tasks_emp_complaint.dto.MessageResponse;
import com.a08r.tasks_emp_complaint.service.AboutAppService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/about-apps")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
@Slf4j
public class AboutAppController {

    private final AboutAppService aboutAppService;

    @PostMapping
    public ResponseEntity<AboutAppResponse> createItem(@Valid @RequestBody AboutAppRequest request) {
        log.info("Received request to create about app: {}", request.getAppName());
        AboutAppResponse response = aboutAppService.createItem(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<AboutAppResponse>> getAllItems() {
        log.info("Received request to get all about apps");
        List<AboutAppResponse> items = aboutAppService.getAllItems();
        return ResponseEntity.ok(items);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AboutAppResponse> getItemById(@PathVariable Long id) {
        log.info("Received request to get about app by id: {}", id);
        AboutAppResponse response = aboutAppService.getItemById(id);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AboutAppResponse> updateItem(@PathVariable Long id,
                                                       @Valid @RequestBody AboutAppRequest request) {
        log.info("Received request to update about app with id: {}", id);
        AboutAppResponse response = aboutAppService.updateItem(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteItem(@PathVariable Long id) {
        log.info("Received request to delete about app with id: {}", id);
        aboutAppService.deleteItem(id);
        return ResponseEntity.ok(new MessageResponse("About app deleted successfully!"));
    }

    @GetMapping("/app/{appName}")
    public ResponseEntity<List<AboutAppResponse>> getByAppName(@PathVariable String appName) {
        log.info("Received request to get about apps by app name: {}", appName);
        List<AboutAppResponse> items = aboutAppService.getByAppName(appName);
        return ResponseEntity.ok(items);
    }

    @GetMapping("/department/{department}")
    public ResponseEntity<List<AboutAppResponse>> getByDepartment(@PathVariable String department) {
        log.info("Received request to get about apps by department: {}", department);
        List<AboutAppResponse> items = aboutAppService.getByDepartment(department);
        return ResponseEntity.ok(items);
    }
}
