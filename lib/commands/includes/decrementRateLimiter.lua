--[[
  Function to decrement rate limiter counter when a job leaves active state.
  
  Input:
    rateLimiterKey - base key for rate limiter
    jobId - job identifier
    hasGroupKey - whether to apply group-based rate limiting
    mode - rate limit mode ("count" or other)
    
  Note: This should be called whenever a job transitions out of active state
  (finished, failed, or stalled) to free up rate limiter slots.
]]

local function decrementRateLimiter(rateLimiterKey, jobId, hasGroupKey, mode)
    if mode == "count" and rateLimiterKey and rateLimiterKey ~= "" then
        -- Apply the same grouping logic as in moveToActive
        local actualRateLimiterKey = rateLimiterKey

        -- Rate limit by group?
        if hasGroupKey and (hasGroupKey == "true" or hasGroupKey == true) then
            local group = string.match(jobId, "[^:]+$")
            if group ~= nil then
                actualRateLimiterKey = rateLimiterKey .. ":" .. group
            end
        end

        local counterKey = actualRateLimiterKey .. ":counter"

        -- Decrement the counter
        if rcall("EXISTS", counterKey) > 0 then
            local currentCount = tonumber(rcall("GET", counterKey)) or 0
            if currentCount > 0 then
                rcall("DECRBY", counterKey, 1)
            end
        end
    end
end