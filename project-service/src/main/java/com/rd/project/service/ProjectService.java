package com.rd.project.service;

import com.rd.project.dto.ProjectRequest;
import com.rd.project.dto.ProjectResponse;
import com.rd.project.model.Project;
import com.rd.project.repository.ProjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProjectService {

    @Autowired
    private ProjectRepository projectRepository;

    public List<ProjectResponse> getAllProjects() {
        return projectRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public ProjectResponse getProjectById(Long id) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found"));
        return toResponse(project);
    }

    @Transactional
    public ProjectResponse createProject(ProjectRequest request) {
        Project project = new Project();
        project.setNom(request.getNom());
        project.setDescription(request.getDescription());
        project.setStatut("DRAFT");

        project = projectRepository.save(project);
        return toResponse(project);
    }

    @Transactional
    public ProjectResponse updateProject(Long id, ProjectRequest request) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found"));

        project.setNom(request.getNom());
        project.setDescription(request.getDescription());

        project = projectRepository.save(project);
        return toResponse(project);
    }

    @Transactional
    public void deleteProject(Long id) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found"));

        projectRepository.delete(project);
    }

    @Transactional
    public ProjectResponse updateStatus(Long id, String statut) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found"));
        project.setStatut(statut);
        project = projectRepository.save(project);
        return toResponse(project);
    }

    private ProjectResponse toResponse(Project project) {
        return new ProjectResponse(
                project.getIdProject(),
                project.getNom(),
                project.getDescription(),
                project.getStatut(),
                project.getCreatedAt(),
                project.getUpdatedAt()
        );
    }
}

