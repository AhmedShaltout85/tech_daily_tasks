package com.ao8r.tasks_api;

import com.ao8r.tasks_api.entity.Role;
import com.ao8r.tasks_api.entity.User;
import com.ao8r.tasks_api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@Profile("test")
@RequiredArgsConstructor
@Slf4j
public class TestDataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (userRepository.count() == 0) {
            log.info("Initializing test data...");

            String encodedPassword = passwordEncoder.encode("test123");

            userRepository.save(User.builder()
                    .displayName("System Administrator")
                    .username("admin")
                    .password(encodedPassword)
                    .role(Role.ADMIN)
                    .department("IT")
                    .isEnabled(true)
                    .build());

            userRepository.save(User.builder()
                    .displayName("Test Manager")
                    .username("manager")
                    .password(encodedPassword)
                    .role(Role.MANAGER)
                    .department("Management")
                    .isEnabled(true)
                    .build());

            userRepository.save(User.builder()
                    .displayName("Test General Manager")
                    .username("generalmanager")
                    .password(encodedPassword)
                    .role(Role.GENERAL_MANAGER)
                    .department("Management")
                    .isEnabled(true)
                    .build());

            userRepository.save(User.builder()
                    .displayName("Test Sector Manager")
                    .username("sectormanager")
                    .password(encodedPassword)
                    .role(Role.SECTOR_MANAGER)
                    .department("Operations")
                    .isEnabled(true)
                    .build());

            userRepository.save(User.builder()
                    .displayName("Test User")
                    .username("user")
                    .password(encodedPassword)
                    .role(Role.USER)
                    .department("User Department")
                    .isEnabled(true)
                    .build());

            log.info("Test data initialized: 5 users created");
        }
    }
}
