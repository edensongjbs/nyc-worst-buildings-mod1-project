class DobViolation < ActiveRecord::Base
    belongs_to :building

    def description
        self.disposition_comments
    end

    def get_date
        date = self.issue_date
        date[0...4] + "-" + date[4...6] + "-" + date[6...]
    end

end
