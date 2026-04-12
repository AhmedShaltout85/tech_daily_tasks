package com.ao8r.tasks_api.controller;

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
@RequiredArgsConstructor
@Slf4j
public class UserController {

    private final UserService userService;

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
}
