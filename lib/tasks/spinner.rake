namespace :spinner do
  desc "Spinner Tasks"
  task mopidy_websocket: :environment do
    Rails.logger       = Logger.new(Rails.root.join('log', 'mopidy_websocket.log'))
    
    if ENV['BACKGROUND']
      Process.daemon(true, true)
    end
    
    if ENV['PIDFILE']
      File.open(ENV['PIDFILE'], 'w') { |f| f << Process.pid }
    end
    
    Signal.trap('TERM') { abort }
    
    @ws = nil
    @ws_backoff_min = 0.5
    @ws_backoff = @ws_backoff_min
    @ws_backoff_max = 60

    EM.run do
      def start_websocket
        ws_uri = Rails.application.secrets.mopidy[:uri].gsub('/rpc', '/ws').gsub('http', 'ws')
        if Rails.application.secrets.mopidy[:username]
          ws_uri.gsub!('://', "://#{Rails.application.secrets.mopidy[:username]}:#{Rails.application.secrets.mopidy[:password]}@")
        end
        
        @ws = Faye::WebSocket::Client.new(ws_uri, nil, ping: 10)
        
        @ws.on :open do |event|
          p [:open]
          @ws_backoff = @ws_backoff_min
        end
        
        @ws.on :message do |event|
          begin
            message = JSON.parse(event.data)
          rescue Exception
            # Meh, not much we can do
            next
          end
          
          if message.has_key?('event')
            case message['event']
            when 'volume_changed'
              # There is a 'volume' key we should (maybe?) pay attention to.
            when 'tracklist_changed'
              # We don't much care about this one, skip it.
              next
            when 'track_playback_started'
              # A track started to play, see if it's one of ours.
              tlid = message['tl_track']['tlid']
              if (qe = QueueEntry.find_by(tlid: tlid))
                # It is. Turn it into a track we've played, which will also
                # queue the next song as a side effect (we delete this queue
                # entry, which then triggers a next-song update).
                qe.turn_into_played_song!
                
                # Tell everyone the current song playing changed.
                ActionCable.server.broadcast('room_channel', {
                  event: 'nowplaying_change',
                })
              end
            end
            
            p [:message, message]
          end
        end
        
        @ws.on :close do |event|
          p [:close, event.code, event.reason]
          ws = nil
          
          sleep @ws_backoff
          @ws_backoff *= 2
          @ws_backoff = @ws_backoff_max if @ws_backoff > @ws_backoff_max
          start_websocket
        end
      end
      
      def periodic_check
        begin
          # Are we playing?
          if MopidyClient.instance.invoke('core.playback.get_state') == 'playing'
            # In theory. Make sure we're not stuck.
            track_pos = MopidyClient.instance.invoke('core.playback.get_time_position')
            if track_pos == 0
              # Check again to see if anything's happening.
              sleep(0.1)
              if MopidyClient.instance.invoke('core.playback.get_time_position') == 0
                # Push on to the next track.
                track_pos = MopidyClient.instance.invoke('core.playback.next')
              end
            end
          else
            # Should we be?
            if (qe = QueueEntry.next_up)
              # Make sure it's in the queue. (This won't double-queue.)
              qe.add_to_mopidy!
              
              MopidyClient.instance.invoke('core.playback.play', [nil, qe.tlid])
            end
          end
        rescue Exception => e
          # Not much we can do, but we shouldn't necessarily bail just because
          # of a timeout.
          puts e.inspect
          puts e.backtrace
        end
      end
      
      EM.add_periodic_timer(Rails.application.secrets.mopidy[:periodic_timer], method(:periodic_check))
      
      start_websocket
      periodic_check
    end
  end
end
