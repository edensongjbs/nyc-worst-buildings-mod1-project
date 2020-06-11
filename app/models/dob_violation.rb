class DobViolation < ActiveRecord::Base
    belongs_to :building

    def description
        self.disposition_comments
    end

end
