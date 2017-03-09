module Socialization
  class << self
    def follow_model
      if @follow_model
        @follow_model
      else
        ::Follow
      end
    end

    def follow_model=(klass)
      @follow_model = klass
    end

    def like_model
      if @like_model
        @like_model
      else
        ::Like
      end
    end

    def like_model=(klass)
      @like_model = klass
    end

    def mention_model
      if @mention_model
        @mention_model
      else
        ::Mention
      end
    end

    def mention_model=(klass)
      @mention_model = klass
    end

    def watch_later_model
      if @watch_later_model
        @watch_later_model
      else
        ::WatchLater
      end
    end

    def watch_later_model=(klass)
      @watch_later_model = klass
    end
  end
end