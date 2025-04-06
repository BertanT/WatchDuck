/*
 wdtime.js
 
 Copyright (C) 2025 Bedir Ekim
 
 This file is part of WatchDuck.
 
 WatchDuck is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 WatchDuck is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License along with WatchDuck.
 If not, see <https://www.gnu.org/licenses/>.
*/

document.addEventListener('DOMContentLoaded', function() {
    formatAllTimestamps();
});

/**
 * Format all timestamp elements on the page.
 */
function formatAllTimestamps() {
    document.querySelectorAll('[data-timestamp]').forEach(formatTimestampElement);

    // Make sure the time zone notice is correct for users who don't have JS enabled
    document.querySelectorAll('.tz-notice-nojs').forEach(e => e.style.display = 'none');
    document.querySelectorAll('.tz-notice-js').forEach(e => e.style.display = 'block');
}

function formatTimestampElement(element) {
    const timestamp = parseInt(element.getAttribute('data-timestamp'), 10) * 1000;
    const date = new Date(timestamp);
    
    const formatType = element.getAttribute('data-format-type') || 'datetime';
    const isRange = element.hasAttribute('data-end-timestamp');
    
    if (isRange) {
        const endTimestamp = parseInt(element.getAttribute('data-end-timestamp'), 10) * 1000;
        const endDate = new Date(endTimestamp);
        element.textContent = formatDateRange(date, endDate);
    } else if (formatType === 'datetime') {
        element.textContent = formatDateTime(date, true);
    } else if (formatType === 'lastupdated') {
        element.textContent = 'Last updated: ' + formatDateTime(date, true);
    } else if (formatType === 'ongoing') {
        element.textContent = 'Down since ' + formatDateTime(date);
    }
}

/**
 * Format a date in a user-friendly format.
 * @param {Date} date - Date to format.
 * @param {Boolean} includeTimezone - Whether to include timezone information.
 * @param {Boolean} isOutageTime - Whether this is for an outage timestamp.
 * @returns {string} Formatted date string.
 */
function formatDateTime(date, includeTimezone = false, isOutageTime = false) {
    if (isOutageTime) {
        const dateStr = date.toLocaleDateString();
        const timeStr = date.toLocaleTimeString(undefined, {
            hour: '2-digit',
            minute: '2-digit'
        });
        return `${dateStr}, ${timeStr}`;
    }
    
    const options = {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    };
    
    const formattedDateTime = date.toLocaleString(undefined, options);
    
    if (includeTimezone) {
        const tzString = getTimezoneString(date);
        return `${formattedDateTime} ${tzString}`;
    }
    
    return formattedDateTime;
}

/**
 * Get the timezone string (like GMT+2) for a date.
 * @param {Date} date - The date to get timezone for.
 * @returns {string} Timezone string.
 */
function getTimezoneString(date) {
    const timezoneOffset = date.getTimezoneOffset();
    const offsetHours = Math.abs(Math.floor(timezoneOffset / 60));
    const offsetMinutes = Math.abs(timezoneOffset % 60);
    const offsetSign = timezoneOffset <= 0 ? '+' : '-';
    
    if (offsetMinutes === 0) {
        return `GMT${offsetSign}${offsetHours}`;
    } else {
        return `GMT${offsetSign}${offsetHours}:${offsetMinutes.toString().padStart(2, '0')}`;
    }
}

/**
 * Format a date range.
 * @param {Date} startDate - Start date.
 * @param {Date} endDate - End date.
 * @returns {string} Formatted date range.
 */
function formatDateRange(startDate, endDate) {
    if (startDate.getFullYear() === endDate.getFullYear() &&
        startDate.getMonth() === endDate.getMonth() &&
        startDate.getDate() === endDate.getDate() &&
        startDate.getHours() === endDate.getHours() &&
        startDate.getMinutes() === endDate.getMinutes()) {
        
        const formattedStart = formatDateTime(startDate, false, true);
        return `${formattedStart} - Resolved under a minute :)`;
    }

    const formattedStart = formatDateTime(startDate, false, true);
    const formattedEnd = formatDateTime(endDate, false, true);
    return `${formattedStart} - ${formattedEnd}`;
}