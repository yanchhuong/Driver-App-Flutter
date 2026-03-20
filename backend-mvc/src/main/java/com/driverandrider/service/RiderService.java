package com.driverandrider.service;

import com.driverandrider.dto.RiderDto;
import com.driverandrider.exception.ResourceNotFoundException;
import com.driverandrider.model.Rider;
import com.driverandrider.repository.RiderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class RiderService {

    private final RiderRepository riderRepository;

    public List<Rider> findAll() {
        return riderRepository.findAll();
    }

    public Rider findById(Long id) {
        return riderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Rider", id));
    }

    public Rider register(RiderDto dto) {
        if (riderRepository.existsByEmail(dto.getEmail())) {
            throw new IllegalStateException("Email already registered: " + dto.getEmail());
        }
        Rider rider = toEntity(dto);
        return riderRepository.save(rider);
    }

    public Rider update(Long id, RiderDto dto) {
        Rider rider = findById(id);
        rider.setName(dto.getName());
        rider.setPhone(dto.getPhone());
        return riderRepository.save(rider);
    }

    public void delete(Long id) {
        Rider rider = findById(id);
        riderRepository.delete(rider);
    }

    private Rider toEntity(RiderDto dto) {
        Rider rider = new Rider();
        rider.setName(dto.getName());
        rider.setEmail(dto.getEmail());
        rider.setPhone(dto.getPhone());
        return rider;
    }
}
