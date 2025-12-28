package com.rd.auth.service;

import com.rd.auth.dto.AuthResponse;
import com.rd.auth.dto.LoginRequest;
import com.rd.auth.dto.RegisterRequest;
import com.rd.auth.dao.entities.Role;
import com.rd.auth.dao.entities.User;
import com.rd.auth.dao.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        // Créer l'utilisateur
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(Role.RESEARCHER);
        user.setEnabled(true);

        // Sauvegarder en base
        User savedUser = userRepository.save(user);

        String accessToken = jwtService.generateToken(savedUser.getUsername(), savedUser.getRole().name(), savedUser.getIdUser());
        String refreshToken = jwtService.generateRefreshToken(savedUser.getUsername());

        return new AuthResponse(accessToken, refreshToken, savedUser.getIdUser(), savedUser.getUsername(), savedUser.getRole().name());


    }

    public AuthResponse login(LoginRequest request) {
        Optional<User> userOpt = userRepository.findByUsername(request.getUsername());
        if (userOpt.isEmpty() || !passwordEncoder.matches(request.getPassword(), userOpt.get().getPassword())) {
            throw new RuntimeException("Invalid username or password");
        }

        User user = userOpt.get();
        if (!user.isEnabled()) {
            throw new RuntimeException("User account is disabled");
        }

        String accessToken = jwtService.generateToken(user.getUsername(), user.getRole().name(), user.getIdUser());
        String refreshToken = jwtService.generateRefreshToken(user.getUsername());

        return new AuthResponse(accessToken, refreshToken, user.getIdUser(), user.getUsername(), user.getRole().name());
    }

    public Boolean validateToken(String token) {
        return jwtService.validateToken(token);
    }
}

