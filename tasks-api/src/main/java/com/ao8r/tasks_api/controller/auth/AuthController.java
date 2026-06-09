package com.ao8r.tasks_api.controller.auth;

import com.ao8r.tasks_api.dto.JwtResponse;
import com.ao8r.tasks_api.dto.MessageResponse;
import com.ao8r.tasks_api.dto.RefreshTokenRequest;
import com.ao8r.tasks_api.dto.SigninRequest;
import com.ao8r.tasks_api.dto.SignupRequest;
import com.ao8r.tasks_api.dto.TokenRefreshResponse;
import com.ao8r.tasks_api.entity.User;
import com.ao8r.tasks_api.security.jwt.JwtUtils;
import com.ao8r.tasks_api.security.services.UserDetailsImpl;
import com.ao8r.tasks_api.security.services.UserDetailsServiceImpl;
import com.ao8r.tasks_api.service.RefreshTokenService;
import com.ao8r.tasks_api.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final UserService userService;
    private final JwtUtils jwtUtils;
    private final RefreshTokenService refreshTokenService;
    private final UserDetailsServiceImpl userDetailsService;

    @PostMapping("/signup")
    public ResponseEntity<MessageResponse> registerUser(@Valid @RequestBody SignupRequest signupRequest) {
        log.info("Signup request received for username: {}", signupRequest.getUsername());
        User user = userService.registerUser(signupRequest);
        return ResponseEntity.ok(new MessageResponse("User registered successfully!"));
    }

    @PostMapping("/signin")
    public ResponseEntity<JwtResponse> authenticateUser(@Valid @RequestBody SigninRequest signinRequest) {
        log.info("Signin request received for username: {}", signinRequest.getUsername());
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(signinRequest.getUsername(), signinRequest.getPassword())
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        String refreshToken = refreshTokenService.createRefreshToken(userDetails.getUsername());

        JwtResponse jwtResponse = JwtResponse.builder()
                .token(jwt)
                .type("Bearer")
                .refreshToken(refreshToken)
                .id(userDetails.getId())
                .username(userDetails.getUsername())
                .displayName(userDetails.getDisplayName())
                .role(userDetails.getRole())
                .department(userDetails.getDepartment())
                .build();

        return ResponseEntity.ok(jwtResponse);
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<TokenRefreshResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        log.info("Refresh token request received");
        String refreshToken = request.getRefreshToken();

        if (!refreshTokenService.validateRefreshToken(refreshToken)) {
            log.error("Invalid or expired refresh token");
            return ResponseEntity.status(401).build();
        }

        String username = refreshTokenService.getUsernameFromRefreshToken(refreshToken);
        UserDetails userDetails = userDetailsService.loadUserByUsername(username);
        String newAccessToken = jwtUtils.generateTokenFromUsername(userDetails);

        TokenRefreshResponse response = TokenRefreshResponse.builder()
                .accessToken(newAccessToken)
                .tokenType("Bearer")
                .refreshToken(refreshToken)
                .build();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/signout")
    public ResponseEntity<MessageResponse> signoutUser(@RequestBody(required = false) RefreshTokenRequest request) {
        log.info("Signout request received");

        if (request != null && request.getRefreshToken() != null) {
            refreshTokenService.revokeRefreshToken(request.getRefreshToken());
        }

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getName() != null) {
            refreshTokenService.revokeAllRefreshTokensForUser(authentication.getName());
        }

        SecurityContextHolder.clearContext();
        return ResponseEntity.ok(new MessageResponse("User signed out successfully!"));
    }
}
