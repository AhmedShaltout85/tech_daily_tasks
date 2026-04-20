package com.ao8r.tasks_api.controller;

import com.ao8r.tasks_api.dto.ChangePasswordRequest;
import com.ao8r.tasks_api.dto.ForgotPasswordRequest;
import com.ao8r.tasks_api.dto.MessageResponse;
import com.ao8r.tasks_api.security.services.UserDetailsImpl;
import com.ao8r.tasks_api.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping
@CrossOrigin(origins ="*" )  // Allow CORS for Flutter Web
@RequiredArgsConstructor
@Slf4j
public class PasswordController {

    private final UserService userService;

    @PutMapping("/api/users/change-password")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<MessageResponse> changePassword(
            @Valid @RequestBody ChangePasswordRequest request,
            Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        log.debug("Change password request for user: {}", userDetails.getUsername());
        userService.changePassword(userDetails.getUsername(), request.getCurrentPassword(), request.getNewPassword());
        return ResponseEntity.ok(new MessageResponse("Password changed successfully!"));
    }

    @PostMapping("/api/auth/forgot-password")
    public ResponseEntity<MessageResponse> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        log.debug("Forgot password request for username: {}", request.getUsername());
        userService.resetPassword(request.getUsername(), request.getNewPassword());
        return ResponseEntity.ok(new MessageResponse("Password reset successfully!"));
    }
}