package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.SignupRequest;
import com.ao8r.tasks_api.entity.Role;
import com.ao8r.tasks_api.entity.User;
import com.ao8r.tasks_api.exception.UserNotFoundException;
import com.ao8r.tasks_api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public User registerUser(SignupRequest request) {
        log.debug("Registering new user with username: {}", request.getUsername());

        if (Boolean.TRUE.equals(userRepository.existsByUsername(request.getUsername()))) {
            throw new RuntimeException("Error: Username is already taken!");
        }

        Role role = Role.USER;
        if (request.getRole() != null && !request.getRole().isEmpty()) {
            try {
                role = Role.valueOf(request.getRole().toUpperCase());
            } catch (IllegalArgumentException e) {
                log.warn("Invalid role specified: {}, defaulting to USER", request.getRole());
            }
        }

        User user = User.builder()
                .displayName(request.getDisplayName())
                .username(request.getUsername())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(role)
                .department(request.getDepartment())
                .isEnabled(true)
                .build();

        User savedUser = userRepository.save(user);
        log.info("User registered successfully: {}", savedUser.getUsername());
        return savedUser;
    }

    @Override
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    @Override
    public Boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    @Override
    public List<User> findByRole(Role role) {
        return userRepository.findByRole(role);
    }

    @Override
    @Transactional
    public User updateUserEnabled(Long id, boolean enabled) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
        user.setEnabled(enabled);
        User updatedUser = userRepository.save(user);
        log.info("User {} enabled status updated to: {}", updatedUser.getUsername(), enabled);
        return updatedUser;
    }

    @Override
    @Transactional
    public void deleteUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
        userRepository.delete(user);
        log.info("User deleted: {}", user.getUsername());
    }
}
