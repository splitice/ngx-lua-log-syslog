#!/usr/bin/lua5.1

local socket = require 'socket'
local S = {hostname="localhost",tag="ngxlua",destination_addr="127.0.0.1",destination_port=514}

if ngx then
	local pid = ngx.worker.pid()
	local udpsock = ngx.socket.udp()
else
	local pid = -1
	local udpsock = socket.udp()
end

-- contants from <sys/syslog.h>
S.LOG_EMERG    =  0       -- system is unusable */
S.LOG_ALERT    =  1       -- action must be taken immediately */
S.LOG_CRIT     =  2       -- critical conditions */
S.LOG_ERR      =  3       -- error conditions */
S.LOG_WARNING  =  4       -- warning conditions */
S.LOG_NOTICE   =  5       -- normal but significant condition */
S.LOG_INFO     =  6       -- informational */
S.LOG_DEBUG    =  7       -- debug-level messages */

S.LOG_KERN     =  (0 *8)  -- kernel messages */
S.LOG_USER     =  (1 *8)  -- random user-level messages */
S.LOG_MAIL     =  (2 *8)  -- mail system */
S.LOG_DAEMON   =  (3 *8)  -- system daemons */
S.LOG_AUTH     =  (4 *8)  -- security/authorization messages */
S.LOG_SYSLOG   =  (5 *8)  -- messages generated internally by syslogd */
S.LOG_LPR      =  (6 *8)  -- line printer subsystem */
S.LOG_NEWS     =  (7 *8)  -- network news subsystem */
S.LOG_UUCP     =  (8 *8)  -- UUCP subsystem */
S.LOG_CRON     =  (9 *8)  -- clock daemon */
S.LOG_AUTHPRIV =  (10 *8) -- security/authorization messages (private) */
S.LOG_FTP      =  (11 *8) -- ftp daemon */

-- other codes through 15 reserved for system use */
S.LOG_LOCAL0   =  (16 *8) -- reserved for local use */
S.LOG_LOCAL1   =  (17 *8) -- reserved for local use */
S.LOG_LOCAL2   =  (18 *8) -- reserved for local use */
S.LOG_LOCAL3   =  (19 *8) -- reserved for local use */
S.LOG_LOCAL4   =  (20 *8) -- reserved for local use */
S.LOG_LOCAL5   =  (21 *8) -- reserved for local use */
S.LOG_LOCAL6   =  (22 *8) -- reserved for local use */
S.LOG_LOCAL7   =  (23 *8) -- reserved for local use */

S.facility=S.LOG_LOCAL5

local function mkprio(fac, sev)
    return fac + sev
end
S.mkprio = mkprio

-- parameter is unix time or nil if now
--local function iso_timestamp(uts)
--    tz = os.date("*t", uts).hour - os.date("!*t", uts).hour
--    if tz < 0 then tz = tz + 24 end
--    tzs = string.format("%.4d", tz * 100)
--    ts = os.date("%Y-%m-%dT%H:%M:%S+", uts)
--    return ts .. tzs
--end

local function mklogline(fac, sev, tag, msg)
    return table.concat(("<", mkprio(fac, sev) ">" , self.myhostname, " ", tag, "[", pid, "]", ": ", msg})
end

local function syslog(fac, sev, tag, msg)
    udpsock:sendto(mklogline(fac, sev, tag, msg), S.destination_addr, S.destination_port)
end
S.syslog = syslog;

local function log_notice(msg)
   syslog(S.facility, S.LOG_NOTICE, S.tag, msg)
end
S.log_notice = log_notice

local function log_error(msg)
   syslog(S.facility, S.LOG_ERR, S.tag, msg)
end
S.log_error = log_error

local function log_warning(msg)
   syslog(S.facility, S.LOG_WARNING, S.tag, msg)
end
S.log_warning = log_warning

return S
