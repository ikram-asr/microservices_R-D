package com.rd.project.dao.repositories;

import com.rd.project.dao.entities.Milestone;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MilestoneRepository extends JpaRepository<Milestone, Long> {
    List<Milestone> findByIdPhase(Long idPhase);
}

