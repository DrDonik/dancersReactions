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

leaders = [randn(initialLeaderPopulation, length(dancerProps) - 4), ... % the personal attributes are normally distributed
    abs(randn(initialLeaderPopulation, 1)*0.1 + 1), ... % the frustration tolerance is a multiplicator and can only be positive
    randn(initialLeaderPopulation, 1) + 10, ... % everybody starts out quite happy
    (1:initialLeaderPopulation)', ... % right now, everybody is partnered. This will be changed in the next subsection
    zeros(initialLeaderPopulation, 1)]; % everybody has not participated at any event 
followers = [randn(initialFollowerPopulation, length(dancerProps) - 4), ...
    abs(randn(initialFollowerPopulation, 1)*0.1 + 1), ...
    randn(initialFollowerPopulation, 1) + 10, ...
    (1:initialFollowerPopulation)', ...
    zeros(initialFollowerPopulation, 1)];

% what part of the dancers is partnered?
partneredRatio = 0.5;
partneredDancers = partneredRatio*min(initialLeaderPopulation,initialLeaderPopulation);
leaders(partneredDancers+1:end, 13)=0; % now the initial population is partially partnered
followers(partneredDancers+1:end, 13)=0;

dancerSummaryFigure = figure;

for i = 1:10
    %% Dancers with negative happiness are no longer part of the scene
    leadersDancingIndex = find(leaders(:, 11) > 0);
    followersDancingIndex = find(leaders(:, 11) > 0);
    
    %% Display the dancers mean happiness values
    errorbar(i, mean(leaders(:,11)), std(leaders(:,11)), 'ro')
    hold on
    errorbar(i, mean(followers(:,11)), std(leaders(:,11)), 'bo')
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

    % update the happiness/motivation of the rejected, depending on their frustration tolerance
    % (it seems as if we degraded all; but we will update the actual participants in the next step)
    leaders(applicantsLeaders, 11) = leaders(applicantsLeaders, 11) - 1./leaders(applicantsLeaders, 10);
    followers(applicantsFollowers, 11) = followers(applicantsFollowers, 11) - 1./followers(applicantsFollowers, 10);

    % update the happiness/motivation of the participants
    leaders(thisEventLeaders, 11) = leaders(thisEventLeaders, 11) + 1;
    followers(thisEventFollowers, 11) = followers(thisEventFollowers, 11) + 1;

end
