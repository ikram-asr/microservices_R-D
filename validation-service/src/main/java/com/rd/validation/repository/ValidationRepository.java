package com.rd.validation.repository;

import com.rd.validation.model.Validation;
import com.rd.validation.model.ValidationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ValidationRepository extends JpaRepository<Validation, Long> {
    List<Validation> findByProjectId(Long projectId);
    List<Validation> findByValidatorId(Long validatorId);
    List<Validation> findByStatus(ValidationStatus status);
}

