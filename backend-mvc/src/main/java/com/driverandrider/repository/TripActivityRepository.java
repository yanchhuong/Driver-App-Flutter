package com.driverandrider.repository;

import com.driverandrider.model.TripActivity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripActivityRepository extends JpaRepository<TripActivity, Long> {

    /** All activities for a trip, oldest first. */
    List<TripActivity> findByTrip_IdOrderByCreatedAtAsc(Long tripId);
}
