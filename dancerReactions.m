%% Initialization
% these are the different properties that make up the dancers stance on
% different topics. 0 is "medium", negative means no, positive means yes
dancerProps = {'planned',...
    'price-sensitive',...
    'roled',...
    'partnered',...
    'outgoing',...
    'equalitarian',...
    'feminist/masculinist',...
    'home-scene bound',...
    'returning',...
    'frustration-tolerant',...
    'happy/motivated',...
    'preferred partner',...
    'visited workshops'...
};

% these are the properties of the registration system
eventProps = {'number of places',...
    'registering schedule',...
    'roled',...
    'partnered preferred',...
    'price-pattern',...
};

leadersRejected = 0;
followersRejected = 0;

% make an initial population of dancers
leadFollowRatio = 0.8;
initialDancerPopulation = 250;
initialLeaderPopulation = round(initialDancerPopulation/2*leadFollowRatio);
initialFollowerPopulation = round(initialDancerPopulation/2/leadFollowRatio);

leaders = [randn(initialLeaderPopulation, length(dancerProps) - 3), ... % the personal attributes are normally distributed
    randn(initialLeaderPopulation, 1) + 1, ... % everybody starts out quite happy
    (1:initialLeaderPopulation)', ... % right now, everybody is partnered. This will be changed in the next subsection
    zeros(initialLeaderPopulation, 1)]; % everybody has not participated at any event 
followers = [randn(initialFollowerPopulation, length(dancerProps) - 3), ...
    randn(initialFollowerPopulation, 1) + 1, ...
    (1:initialFollowerPopulation)', ...
    zeros(initialFollowerPopulation, 1)];

% what part of the dancers is partnered?
partneredRatio = 0.5;
partneredDancers = partneredRatio*min(initialLeaderPopulation,initialLeaderPopulation);
leaders(partneredDancers+1:end, 13)=0; % now the initial population is partially partnered
followers(partneredDancers+1:end, 13)=0;

for i = 1:10
%% Display the dancers mean values
disp(['Leaders'' happiness: ', num2str(mean(leaders(:,11)))])
disp(['Followers'' happiness: ', num2str(mean(followers(:,11)))])

%% Start an event registration and check who is getting in
% set the properties of an event
thisEventProps = [100,1,1,1,1];

% not all will want to participate (currently about half)
applicantsLeaders = logical(randi(2,1,length(leaders))' - 1);
applicantsLeaders = find(applicantsLeaders);
thisEventLeaders = leaders(applicantsLeaders, :);
applicantsFollowers = logical(randi(2,1,length(followers))' - 1);
applicantsFollowers = find(applicantsFollowers);
thisEventFollowers = followers(applicantsFollowers, :);

% sort the population by their planned-attributed, modified by their motivation
% the more planned and the more happy/motivated they are, the earlier will
% the register
[~, indexLeaders] = sort(thisEventLeaders(:, 1) + thisEventLeaders(:, 11), 1, 'descend');
thisEventLeaders = applicantsLeaders(indexLeaders);
[~, indexFollowers] = sort(thisEventFollowers(:, 1) + thisEventFollowers(:, 11), 1, 'descend');
thisEventFollowers = applicantsFollowers(indexFollowers);

switch thisEventProps(3)
    case 0
        % this is an un-roled event
        
    case 1
        % this is a roled event
        
        % find who made it into the workshop
        thisEventLeaders = thisEventLeaders(1:min(length(thisEventLeaders),thisEventProps(1)/2),:);
        thisEventFollowers = thisEventFollowers(1:min(length(thisEventFollowers),length(thisEventLeaders)),:);
        thisEventLeaders = thisEventLeaders(1:min(length(thisEventLeaders),length(thisEventFollowers)),:);
        
    case 2
        % this is a partnered event
end

% keep a total of how many got rejected at all events
leadersRejected = leadersRejected + length(applicantsLeaders) - length(thisEventLeaders);
followersRejected = followersRejected + length(applicantsFollowers) - length(thisEventFollowers);

% mark the participation for each dancer
leaders(thisEventLeaders, 13) = leaders(thisEventLeaders, 13) + 1;
followers(thisEventFollowers, 13) = followers(thisEventFollowers, 13) + 1;

% the happiness/motivation of everybody goes down with time
leaders(:, 11) = leaders(:, 11) - 0.05;
followers(:, 11) = followers(:, 11) - 0.05;

% update the happiness/motivation of the rejected (it seems as if we
% degraded all; instead, we will update the participants double as much)
leaders(applicantsLeaders, 11) = leaders(applicantsLeaders, 11) - 0.1;
followers(applicantsFollowers, 11) = followers(applicantsFollowers, 11) - 0.1;

% update the happiness/motivation of the participants
leaders(thisEventLeaders, 11) = leaders(thisEventLeaders, 11) + 0.2;
followers(thisEventFollowers, 11) = followers(thisEventFollowers, 11) + 0.2;

end