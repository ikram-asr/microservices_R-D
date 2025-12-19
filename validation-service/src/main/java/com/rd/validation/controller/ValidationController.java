package com.rd.validation.controller;

import com.rd.validation.dto.ValidationRequest;
import com.rd.validation.dto.ValidationResponse;
import com.rd.validation.service.ValidationService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/validations")
public class ValidationController {

    @Autowired
    private ValidationService validationService;

    @GetMapping
    public ResponseEntity<List<ValidationResponse>> getAllValidations() {
        return ResponseEntity.ok(validationService.getAllValidations());
    }

    @GetMapping("/project/{idProject}")
    public ResponseEntity<List<ValidationResponse>> getValidationsByProject(@PathVariable Long idProject) {
        return ResponseEntity.ok(validationService.getValidationsByProject(idProject));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ValidationResponse> getValidationById(@PathVariable Long id) {
        try {
            ValidationResponse validation = validationService.getValidationById(id);
            return ResponseEntity.ok(validation);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    public ResponseEntity<ValidationResponse> createValidation(
            @Valid @RequestBody ValidationRequest request) {
        try {
            ValidationResponse validation = validationService.createValidation(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(validation);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ValidationResponse> updateValidation(
            @PathVariable Long id,
            @Valid @RequestBody ValidationRequest request) {
        try {
            ValidationResponse validation = validationService.updateValidation(id, request);
            return ResponseEntity.ok(validation);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
    }
}

