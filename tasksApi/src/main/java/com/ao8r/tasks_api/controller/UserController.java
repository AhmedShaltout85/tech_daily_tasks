package com.ao8r.tasks_api.controller;

import com.ao8r.tasks_api.dto.MessageResponse;
import com.ao8r.tasks_api.entity.Role;
import com.ao8r.tasks_api.entity.User;
import com.ao8r.tasks_api.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins ="*" )  // Allow CORS for Flutter Web
@RequiredArgsConstructor
@Slf4j
public class UserController {

    private final UserService userService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public ResponseEntity<List<User>> getAllUsers() {
        log.debug("Fetching all users");
        List<User> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        log.debug("Fetching user by id: {}", id);
        User user = userService.findUserById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        return ResponseEntity.ok(user);
    }

    @GetMapping("/role/{role}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public ResponseEntity<List<String>> getUsersByRole(@PathVariable Role role) {
        log.debug("Fetching users with role: {}", role);
        List<User> users = userService.findByRole(role);
        List<String> userNames = users.stream()
                .map(User::getUsername)
                .toList();
        return ResponseEntity.ok(userNames);
    }

    @GetMapping("/department/{department}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public ResponseEntity<List<String>> getUsersByDepartment(@PathVariable String department) {
        log.debug("Fetching users with department: {}", department);
        List<User> users = userService.findByDepartment(department);
        List<String> userNames = users.stream()
                .map(User::getUsername)
                .toList();
        return ResponseEntity.ok(userNames);
    }

    @GetMapping("/role/{role}/enabled/{enabled}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public ResponseEntity<List<String>> getUsersByRoleAndEnabled(
            @PathVariable Role role,
            @PathVariable boolean enabled) {
        log.debug("Fetching {} users with role: {} and enabled: {}", enabled ? "enabled" : "disabled", role);
        List<User> users = userService.findByRoleAndIsEnabled(role, enabled);
        List<String> userNames = users.stream()
                .map(User::getUsername)
                .toList();
        return ResponseEntity.ok(userNames);
    }

    @PutMapping("/{id}/enable")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MessageResponse> updateUserEnabled(
            @PathVariable Long id,
            @RequestParam boolean enabled) {
        log.debug("Updating user {} enabled status to: {}", id, enabled);
        userService.updateUserEnabled(id, enabled);
        return ResponseEntity.ok(new MessageResponse("User enabled status updated successfully!"));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MessageResponse> deleteUser(@PathVariable Long id) {
        log.debug("Deleting user with id: {}", id);
        userService.deleteUser(id);
        return ResponseEntity.ok(new MessageResponse("User deleted successfully!"));
    }

    @GetMapping("/roles")
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public ResponseEntity<List<String>> getAllRoles() {
        log.debug("Fetching all roles");
        List<String> roles = userService.getAllRoles();
        return ResponseEntity.ok(roles);
    }
}