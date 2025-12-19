package com.rd.validation.dao.repositories;

import com.rd.validation.dao.entities.ValidationStep;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ValidationStepRepository extends JpaRepository<ValidationStep, Long> {
    List<ValidationStep> findByIdValidation(Long idValidation);
    List<ValidationStep> findByReviewerId(Long reviewerId);
}

