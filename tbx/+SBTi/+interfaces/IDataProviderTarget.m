classdef IDataProviderTarget

    properties
        company_id (1,1) string
        target_type (1,1) string
        intensity_metric (1,1) string
        scope (1,1) string
        coverage_s1 (1,1) double
        coverage_s2 (1,1) double
        coverage_s3 (1,1) double
        reduction_ambition (1,1) double
        base_year (1,1) int64
        base_year_ghg_s1 (1,1) double
        base_year_ghg_s2 (1,1) double
        base_year_ghg_s3 (1,1) double
        start_year (1,1) int64
        end_year (1,1) int64
        time_frame (1,1) string = missing
        achieved_reduction (1,1) double = 0
    end

    methods

        function obj = IDataProviderTarget(varargin)

            if nargin > 0

                if nargin == 1 && istable(varargin{1})

                    tb = varargin{1};

                else

                    tb = table(varargin{2:2:end}, 'VariableNames', string(varargin(1:2:end)));

                end

                obj(height(tb),1) = obj;
                vars = tb.Properties.VariableNames;

                for i = 1 : height(tb)
                    obj(i).company_id         = tb{i,'company_id'};
                    obj(i).target_type        = tb{i,'target_type'};
                    if ismember('intensity_metric',vars)
                        obj(i).intensity_metric   = tb{i,'intensity_metric'};
                    end
                    obj(i).scope              = tb{i,'scope'};
                    obj(i).coverage_s1        = tb{i,'coverage_s1'};
                    obj(i).coverage_s2        = tb{i,'coverage_s2'};
                    obj(i).coverage_s3        = tb{i,'coverage_s3'};
                    obj(i).reduction_ambition = tb{i,'reduction_ambition'};
                    obj(i).base_year          = tb{i,'base_year'};
                    obj(i).base_year_ghg_s1   = tb{i,'base_year_ghg_s1'};
                    obj(i).base_year_ghg_s2   = tb{i,'base_year_ghg_s2'};
                    obj(i).base_year_ghg_s3   = tb{i,'base_year_ghg_s3'};
                    if ismember('start_year',vars)
                        obj(i).start_year   = tb{i,'start_year'};
                    end
                    obj(i).end_year           = tb{i,'end_year'};
                    if ismember('time_frame',vars)
                        obj(i).time_frame   = tb{i,'time_frame'};
                    end
                    if ismember('achieved_reduction',vars)
                        obj(i).achieved_reduction   = tb{i,'achieved_reduction'};
                    end
                end

            end

        end

        function value = toTable(obj)
            value = table([obj.company_id]', [obj.target_type]', [obj.intensity_metric]', [obj.scope]', [obj.coverage_s1]', [obj.coverage_s2]',...
                [obj.coverage_s3]', [obj.reduction_ambition]', [obj.base_year]', [obj.base_year_ghg_s1]', [obj.base_year_ghg_s2]', ...
                [obj.base_year_ghg_s3]', [obj.start_year]', [obj.end_year]', [obj.time_frame]', [obj.achieved_reduction]', ...
                'VariableNames',string(properties(obj))');
        end

    end

end
%  properties (Access = private)
%         data table = table('Size', [0, 16], 'VariableNames', ...
%             {'company_id', 'target_type', 'intensity_metric', 'scope', 'coverage_s1', 'coverage_s2',...
%              'coverage_s3', 'reduction_ambition', 'base_year', 'base_year_ghg_s1', 'base_year_ghg_s2', ...
%               'base_year_ghg_s3', 'start_year', 'end_year', 'time_frame', 'achieved_reduction'}, ...
%               'VariableTypes',{'string','string','string','string','double','double','double',...
%               'double','double','double','double','double','double','double','string','double'});
%     end
%
%     properties (Dependent)
%         company_id
%         target_type
%         intensity_metric
%         scope
%         coverage_s1
%         coverage_s2
%         coverage_s3
%         reduction_ambition
%         base_year
%         base_year_ghg_s1
%         base_year_ghg_s2
%         base_year_ghg_s3
%         start_year
%         end_year
%         time_frame
%         achieved_reduction
%     end
%
% %     properties
% %         company_id (1,1) string
% %         target_type (1,1) string
% %         intensity_metric (1,1) string
% %         scope (1,1) string
% %         coverage_s1 (1,1) double
% %         coverage_s2 (1,1) double
% %         coverage_s3 (1,1) double
% %         reduction_ambition (1,1) double
% %         base_year (1,1) int64
% %         base_year_ghg_s1 (1,1) double
% %         base_year_ghg_s2 (1,1) double
% %         base_year_ghg_s3 (1,1) double
% %         start_year (1,1) int64
% %         end_year (1,1) int64
% %         time_frame (1,1) string
% %         achieved_reduction (1,1) double = 0
% %     end
%
%     methods
%
%         function obj = IDataProviderTarget(varargin)
%
%             if nargin == 1 && istable(varargin{1})
%
%                 tb = varargin{1};
% %                 obj(height(tb),1) = obj;
%                 vars = tb.Properties.VariableNames;
%
%                 if ~ismember('intensity_metric',vars)
%                     tb.intensity_metric = repmat(missing, height(tb),1);
%                 end
%                 if ~ismember('start_year',vars)
%                     tb.start_year = NaN(height(tb),1);
%                 end
%
%                 if ~ismember('time_frame',vars)
%                     tb.time_frame = repmat(missing, height(tb),1);
%                 end
%
%                 if ~ismember('achieved_reduction',vars)
%                     tb.achieved_reduction = zeros(height(tb),1);
%                 end
%
%                 obj.data = tb;
%
%             end
%         end
%
%         function value = toTable(obj)
%             value = obj.data;
%         end
%     end
%
%     methods
%         function value = get.company_id(obj)
%             value = obj.data.company_id;
%         end
%
%         function value = get.target_type(obj)
%             value = obj.data.target_type;
%         end
%
%         function value = get.intensity_metric(obj)
%             value = obj.data.intensity_metric;
%         end
%
%         function value = get.scope(obj)
%             value = obj.data.scope;
%         end
%
%         function value = get.coverage_s1(obj)
%             value = obj.data.coverage_s1;
%         end
%
%         function value = get.coverage_s2(obj)
%             value = obj.data.coverage_s2;
%         end
%
%         function value = get.coverage_s3(obj)
%             value = obj.data.coverage_s3;
%         end
%
%         function value = get.reduction_ambition(obj)
%             value = obj.data.reduction_ambition;
%         end
%         function value = get.base_year(obj)
%             value = obj.data.base_year;
%         end
%         function value = get.base_year_ghg_s1(obj)
%             value = obj.data.base_year_ghg_s1;
%         end
%         function value = get.base_year_ghg_s2(obj)
%             value = obj.data.base_year_ghg_s2;
%         end
%         function value = get.base_year_ghg_s3(obj)
%             value = obj.data.base_year_ghg_s3;
%         end
%         function value = get.start_year(obj)
%             value = obj.data.start_year;
%         end
%         function value = get.end_year(obj)
%             value = obj.data.end_year;
%         end
%         function value = get.time_frame(obj)
%             value = obj.data.time_frame;
%         end
%         function value = get.achieved_reduction(obj)
%             value = obj.data.achieved_reduction;
%         end
%     end
%
% end